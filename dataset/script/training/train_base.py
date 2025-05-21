from transformers import WhisperProcessor, WhisperForConditionalGeneration, Trainer
from transformers import Seq2SeqTrainingArguments as TrainingArguments
from datasets import Audio
import torch
import numpy as np
import torchaudio
from load_teochew_dataset import load_teochew_dataset
import os
from datasets import Audio
import evaluate
from datasets import load_from_disk
from data_collator import DataCollatorSpeechSeq2SeqWithPadding
from torch.utils.tensorboard import SummaryWriter

# Load dataset
dataset = load_teochew_dataset()
dataset = dataset.cast_column("audio", Audio())

# Filter out clips longer than 30 seconds
# dataset = dataset.filter(lambda x: x["audio"]["duration"] <= 30.0)

# Load processor and model
model_name = "openai/whisper-base"
processor = WhisperProcessor.from_pretrained(model_name)
model = WhisperForConditionalGeneration.from_pretrained(model_name)

# Freeze encoder to speed up training / reduce overfitting
for param in model.model.encoder.parameters():
    param.requires_grad = False
model.gradient_checkpointing_enable()

# Preprocessing
def preprocess(batch):
    audio = batch["audio"]
    waveform_np = np.array(audio["array"])
    waveform = torch.from_numpy(waveform_np).float()
    orig_sr = audio["sampling_rate"]

    if orig_sr != 16000:
        waveform = waveform.double().unsqueeze(0)
        resampler = torchaudio.transforms.Resample(orig_freq=orig_sr, new_freq=16000)
        waveform = resampler(waveform).squeeze(0)
        audio_array = waveform.float().numpy()
    else:
        audio_array = waveform_np.astype(np.float32)

    inputs = processor(audio_array, sampling_rate=16000, return_tensors="pt")
    input_features = inputs.input_features[0]
    labels = processor.tokenizer(batch["sentence"]).input_ids
    labels = torch.tensor(labels, dtype=torch.long)

    return {
        "input_features": input_features,
        "labels": labels
    }

# Load and split dataset
dataset = load_teochew_dataset()
dataset = dataset.cast_column("audio", Audio())
splits = dataset.train_test_split(test_size=0.1)

# Use saved processed datasets if available
if os.path.exists("processed_train") and os.path.exists("processed_eval"):
    train_dataset = load_from_disk("processed_train")
    eval_dataset = load_from_disk("processed_eval")
else:
    train_dataset = splits["train"].map(preprocess)
    eval_dataset = splits["test"].map(preprocess)

    train_dataset.save_to_disk("processed_train")
    eval_dataset.save_to_disk("processed_eval")

# Load WER metric
wer_metric = evaluate.load("wer")
writer = SummaryWriter(log_dir="./logs/samples")

def compute_metrics(pred):
    print("🧪 compute_metrics called")

    pred_ids = pred.predictions
    label_ids = pred.label_ids

    if isinstance(pred_ids, tuple):
        pred_ids = pred_ids[0]

    print(f"🔍 pred_ids raw shape: {np.array(pred_ids).shape}")

    # Convert logits to predicted token IDs
    pred_ids = np.argmax(pred_ids, axis=-1)

    # Flatten
        # Flatten predictions to list[int]
    def flatten_ids(p):
        try:
            return list(np.array(p).flatten().astype(int))
        except Exception as e:
            print("❌ Flatten failed:", e)
            print("Bad input:", p)
            return []
        
    pred_ids = [flatten_ids(p) for p in pred_ids]
    label_ids = [flatten_ids(l) for l in label_ids]

    print("✅ Flattening done")

    # Decode
    try:
        pred_str = processor.tokenizer.batch_decode(pred_ids, skip_special_tokens=True)
        label_str = processor.tokenizer.batch_decode(label_ids, skip_special_tokens=True)
    except Exception as e:
        print("❌ batch_decode failed:", e)
        return {"wer": 999.0}

    for i in range(min(3, len(pred_str))):
        writer.add_text(f"eval/sample_{i}",
            f"**Prediction:** {pred_str[i]}\n\n**Reference:** {label_str[i]}",
            global_step=trainer.state.global_step)

    return {"wer": wer_metric.compute(predictions=pred_str, references=label_str)}


# Detect checkpoint for resume
output_dir = "./whisper-teochew-base"
last_checkpoint = None
if os.path.isdir(output_dir):
    checkpoints = [os.path.join(output_dir, d) for d in os.listdir(output_dir) if d.startswith("checkpoint")]
    if checkpoints:
        last_checkpoint = sorted(checkpoints, key=os.path.getmtime)[-1]
        print(f"🔁 Resuming from checkpoint: {last_checkpoint}")

# Define TrainingArguments
training_args = TrainingArguments(
    output_dir=output_dir,                     # where checkpoints go
    per_device_train_batch_size=1,            # safe for Mac/M1 RAM
    num_train_epochs=3,                       # full loop over data
    learning_rate=1e-5,                       # good default for Whisper
    warmup_steps=20,                          # short warmup → fast learning start
    logging_dir="./logs",                     # for TensorBoard
    logging_strategy="steps",
    logging_steps=10,                         # frequent logging
    save_strategy="steps",
    save_steps=1000,
    save_total_limit=3,                       # rotate last 3 checkpoints
    evaluation_strategy="steps",
    eval_steps=1000,
    report_to="tensorboard",                  # enables TB logging
    generation_max_length=225,                # controls decode length
    predict_with_generate=True,              # ensures full sequence decoding
    load_best_model_at_end=True,             # useful for deployment/final eval
    metric_for_best_model="wer",
    greater_is_better=False,                 # lower WER is better
    disable_tqdm=False,                       # keep training bar visible
    # max_steps=12,  # for debug mode
)
data_collator = DataCollatorSpeechSeq2SeqWithPadding(processor=processor)

# TEMP: limit eval dataset for testing code
# eval_dataset = eval_dataset.select(range(12))
# train_dataset = train_dataset.select(range(12))  

# Trainer setup
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
    eval_dataset=eval_dataset,
    tokenizer=processor,
    compute_metrics=compute_metrics,
    data_collator=data_collator
)

# Train
trainer.train(resume_from_checkpoint=last_checkpoint)
print("✅ Training complete.")
writer.close()
