import { useState, useMemo } from 'react';

function App() {
  const [data, setData] = useState([]);
  const [clipsBaseUrl, setClipsBaseUrl] = useState('http://localhost:8000/clips/');
  const [framesBatchBaseUrl, setFramesBatchBaseUrl] = useState('http://localhost:8000/frames_batch/');
  const [currentPage, setCurrentPage] = useState(0);
  const itemsPerPage = 50;

  const handleClipsBaseUrlChange = (e) => setClipsBaseUrl(e.target.value);
  const handleFramesBatchBaseUrlChange = (e) => setFramesBatchBaseUrl(e.target.value);

  const handleMetadataFileChange = (event) => {
    const file = event.target.files[0];
    if (file?.type !== 'application/json') {
      alert('Please upload a valid JSON file.');
      return;
    }
    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const parsedData = JSON.parse(e.target.result);
        if (Array.isArray(parsedData)) {
          setData(parsedData);
          setCurrentPage(0);
        } else {
          alert('Invalid JSON structure. Expected an array.');
        }
      } catch {
        alert('Error parsing JSON file. Please ensure it\'s valid JSON.');
      }
    };
    reader.readAsText(file);
  };

  const joinUrlParts = (base, relative) => {
    const trimmedBase = base.endsWith('/') ? base.slice(0, -1) : base;
    const trimmedRelative = relative.startsWith('/') ? relative.slice(1) : relative;
    return `${trimmedBase}/${trimmedRelative}`;
  };

  const getAudioUrl = (clipPath) => joinUrlParts(clipsBaseUrl, clipPath);

  const getImageUrl = (clipPath) => {
    try {
      const [videoId, clipFileName] = clipPath.split('/');
      const match = clipFileName.match(/_(\d+)\.wav$/);
      if (match?.[1]) {
        const frameIndex = String(parseInt(match[1], 10) + 1).padStart(4, '0');
        return joinUrlParts(framesBatchBaseUrl, `${videoId}/frame_${frameIndex}.jpg`);
      }
    } catch {
      console.log("error getting image")
    }
    return 'https://placehold.co/200x120/FFC0CB/000000?text=Image+Not+Found';
  };

  const handleTextChange = (clipPath, newText) => {
    setData((prev) =>
      prev.map((item) =>
        item.clip === clipPath ? { ...item, text: newText } : item
      )
    );
  };  

  const getClipId = (clipPath) => clipPath.split('/')[1]?.replace('.wav', '') || clipPath;

  const handleDelete = (clipPath) => {
    setData((prev) => prev.filter((item) => item.clip !== clipPath));
  };

  const handleDownload = () => {
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = 'metadata-edited.json';
    link.click();
    URL.revokeObjectURL(url);
  };

  const handleSave = async () => {
    try {
      const fileHandle = await window.showSaveFilePicker({
        suggestedName: 'metadata-edited.json',
        types: [{
          description: 'JSON Files',
          accept: { 'application/json': ['.json'] }
        }],
      });
  
      const writable = await fileHandle.createWritable();
      await writable.write(JSON.stringify(data, null, 2));
      await writable.close();
  
      alert('File saved successfully!');
    } catch (err) {
      if (err.name !== 'AbortError') {
        console.error('Save failed:', err);
        alert('Failed to save file.');
      }
    }
  };
  

  const paginatedData = useMemo(() => {
    const start = currentPage * itemsPerPage;
    return data.slice(start, start + itemsPerPage);
  }, [data, currentPage]);

  const totalPages = Math.ceil(data.length / itemsPerPage);

  return (
    <div className="min-h-screen bg-gray-50 px-4 py-8 font-sans antialiased">
      <div className="sm:px-2 lg:px-8 py-6">
        <h1 className="text-3xl font-extrabold text-gray-900 mb-8 text-center rounded-md bg-white p-4 shadow-sm">
          Metadata Fixer
        </h1>

        <div className="bg-white shadow-xl overflow-visible sm:rounded-lg mb-8">
          <div className="p-2">
            <h2 className="text-xl font-semibold text-gray-800 mb-4">Import Data</h2>
            <div className="flex flex-col sm:flex-row items-center space-y-4 sm:space-y-0 sm:space-x-4">
              <div className="flex-1 w-full sm:w-auto">
                <label htmlFor="clipsBaseUrl" className="block text-sm font-medium text-gray-700">Clips/Metadata Base URL:</label>
                <input type="text" id="clipsBaseUrl" value={clipsBaseUrl} onChange={handleClipsBaseUrlChange} className="mt-1 block w-full p-2 border border-gray-300 rounded-md shadow-sm" />
              </div>
              <div className="flex-1 w-full sm:w-auto">
                <label htmlFor="framesBatchBaseUrl" className="block text-sm font-medium text-gray-700">Frames Base URL:</label>
                <input type="text" id="framesBatchBaseUrl" value={framesBatchBaseUrl} onChange={handleFramesBatchBaseUrlChange} className="mt-1 block w-full p-2 border border-gray-300 rounded-md shadow-sm" />
              </div>
              <div className="flex-1 w-full sm:w-auto">
                <label htmlFor="metadataFile" className="block text-sm font-medium text-gray-700">Import metadata.json:</label>
                <input type="file" id="metadataFile" accept=".json" onChange={handleMetadataFileChange} className="mt-1 block w-full text-sm text-gray-500" />
              </div>
            </div>
          </div>
        </div>

        {data.length > 0 ? (
          <div className="bg-white shadow-xl overflow-visible sm:rounded-lg">
            <div className="sticky top-0 z-30 bg-white shadow-md border-b px-4 py-3 flex justify-between items-center">
              <h2 className="text-xl font-semibold text-gray-800">Clips List</h2>
              <button onClick={handleSave} className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 shadow">
                💾 Download Edited JSON
              </button>
            </div>
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50 sticky top-[6px] z-20">
                  <tr>
                    <th className="px-2 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                    {/* <th className="px-2 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Clip ID</th> */}
                    <th className="px-2 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Audio Clip</th>
                    <th className="px-2 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Text</th>
                    <th className="px-2 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Image</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {paginatedData.map((item) => (
                    <tr className="hover:bg-gray-50 transition duration-150 ease-in-out">
                      <td className="px-2 py-4 whitespace-nowrap text-sm text-red-600 text-center w-[50px]">
                        <button onClick={() => window.confirm('Are you sure?') && handleDelete(item.clip)} className="font-medium">🗑️</button>
                      </td>
                      {/* <td className="px-2 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{getClipId(item.clip)}</td> */}
                      <td className="px-2 py-4 whitespace-nowrap text-sm text-gray-500 w-[280px]">
                        <div className="mb-1">{getClipId(item.clip)}</div>
                        <audio key={item.clip} controls className="w-full max-w-[250px] rounded-md">
                          <source src={getAudioUrl(item.clip)} type="audio/wav" />
                        </audio>
                      </td>
                      <td className="px-2 py-4 whitespace-nowrap text-sm text-gray-500 w-[500px]">
                        <input type="text" value={item.text} onChange={(e) => handleTextChange(item.clip, e.target.value)} className="w-full p-2 border border-gray-300 rounded-md shadow-sm" />
                      </td>
                      <td className="px-2 py-4 text-sm text-gray-500 align-middle" style={{ height: '100px' }}>
                          <img
                            src={getImageUrl(item.clip)}
                            alt="Frame"
                            className="h-full max-w-[500px] object-contain"
                            onError={(e) => {
                              e.target.onerror = null;
                              e.target.src = 'https://placehold.co/300x160/FFC0CB/000000?text=Image+Load+Error';
                            }}
                          />
                        </td>
                    </tr>
                  ))}
                </tbody>
              </table>
              <div className="flex justify-center items-center py-4 gap-4">
                <button onClick={() => setCurrentPage(p => Math.max(0, p - 1))} disabled={currentPage === 0} className="px-3 py-1 rounded bg-gray-200 hover:bg-gray-300 disabled:opacity-50">Previous</button>
                <span className="text-sm text-gray-700">Page</span>
                <input
                  type="number"
                  min="1"
                  max={totalPages}
                  value={currentPage + 1}
                  onChange={(e) => {
                    const value = parseInt(e.target.value, 10);
                    if (!isNaN(value) && value >= 1 && value <= totalPages) {
                      setCurrentPage(value - 1);
                    }
                  }}
                  className="w-16 text-center border border-gray-300 rounded px-2 py-1 text-sm"
                />
                <span className="text-sm text-gray-700">of {totalPages}</span>
                <button onClick={() => setCurrentPage(p => Math.min(totalPages - 1, p + 1))} disabled={currentPage + 1 >= totalPages} className="px-3 py-1 rounded bg-gray-200 hover:bg-gray-300 disabled:opacity-50">Next</button>
              </div>
            </div>
          </div>
        ) : (
          <div className="bg-white shadow-xl overflow-hidden sm:rounded-lg p-6 text-center text-gray-600">
            No metadata loaded. Please import a `metadata.json` file above.
          </div>
        )}
      </div>
    </div>
  );
}

export default App;
