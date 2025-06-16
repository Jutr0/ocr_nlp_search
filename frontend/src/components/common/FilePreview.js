import React, {useState} from 'react';
import {Box, Typography} from '@mui/material';
import {Document, Page, pdfjs} from 'react-pdf';

pdfjs.GlobalWorkerOptions.workerSrc = new URL(
    'pdfjs-dist/build/pdf.worker.mjs',
    import.meta.url
).toString();

const FilePreview = ({file}) => {
    const [numPages, setNumPages] = useState(null);

    if (!file || !file.type || !file.url) return null;

    const isImage = file.type === 'image/jpeg' || file.type === 'image/png';
    const isPDF = file.type === 'application/pdf';

    const onDocumentLoadSuccess = ({numPages}) => {
        setNumPages(numPages);
    };

    if (!isImage && !isPDF) {
        return (
            <Typography color="text.secondary">
                No preview available for file type: {file.type}
            </Typography>
        );
    }

    return (
        <Box display="flex" flexDirection="column" alignItems="center" gap={2} maxHeight="100%" overflow='auto'>
            {isImage && (
                <Box
                    component="img"
                    src={file.url}
                    alt={file.filename}
                    sx={{
                        maxWidth: '100%',
                        height: '100%',
                        objectFit: 'contain',
                        borderRadius: 1,
                    }}
                />
            )}

            {isPDF && (

                <Document
                    key={file.url}
                    file={file.url}
                    onLoadSuccess={onDocumentLoadSuccess}
                    loading="Loading PDF..."
                >
                    {Array.from(new Array(numPages), (_, i) => (
                        <Page
                            key={`page_${i + 1}`}
                            pageNumber={i + 1}
                            width={Math.min(800, window.innerWidth * 0.9)}
                            renderAnnotationLayer={false}
                            renderTextLayer={false}
                        />
                    ))}
                </Document>
            )}
        </Box>
    );
};

export default FilePreview;
