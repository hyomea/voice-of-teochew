import cv2
import numpy as np
from difflib import SequenceMatcher

class OCREngine:
    def __init__(self, engine_type='paddle', lang='ch'):
        self.engine_type = engine_type.lower()
        self.lang = lang

        if self.engine_type == 'easy':
            import easyocr
            self.reader = easyocr.Reader([lang])
        elif self.engine_type == 'paddle':
            from paddleocr import PaddleOCR
            self.reader = PaddleOCR(
                lang=lang,
                use_angle_cls=True
            )
        else:
            raise ValueError("Unsupported OCR engine: choose 'easy' or 'paddle'")

    def recognize(self, image, conf_threshold=0.35):
        try:
            result = self.reader.ocr(image)

            if not result or not isinstance(result, list) or not isinstance(result[0], dict):
                print("[Warning] Unexpected OCR result structure, skipping.")
                return ""

            texts = []
            for block in result:
                rec_texts = block.get("rec_texts", [])
                rec_scores = block.get("rec_scores", [])
                for text, score in zip(rec_texts, rec_scores):
                    if score >= conf_threshold:
                        texts.append(text)

            return " ".join(texts).strip()

        except Exception as e:
            print(f"[Error] OCR failed: {e}")
            return ""

    @staticmethod
    def is_similar(a, b, threshold=0.6):
        return SequenceMatcher(None, a, b).ratio() >= threshold