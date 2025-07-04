import React from 'react';
import {Box, Button, Paper, Stack, Typography} from '@mui/material';

const DocumentCard = ({document}) => {
    const isImage = (type) => type?.startsWith('image/');

    return (
        <Paper elevation={3} sx={{p: 3, maxWidth: 350, mx: 'auto'}}>
            <Typography variant="subtitle2">{document.file.filename}</Typography>
            <Box sx={{my: 2, borderBottom: '1px solid #ccc', pb: 2}}>
                <Box
                    sx={{
                        height: 200,
                        backgroundColor: '#f5f5f5',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        overflow: 'hidden',
                    }}
                >
                    {isImage(document.file.type) ? (
                        <img
                            src={document.file.url}
                            alt="Preview"
                            style={{
                                width: '100%',
                                height: '100%',
                                objectFit: 'cover',
                            }}
                        />
                    ) : (
                        <Typography variant="caption" color="textSecondary">
                            No preview available
                        </Typography>
                    )}
                </Box>
            </Box>
            <Box sx={{mb: 3}}>
                <Typography variant="subtitle1" fontWeight="bold">Extracted data:</Typography>
                <Typography>Category: {document.category}</Typography>
                <Typography>Document type: {document.doc_type}</Typography>
                <Typography>Gross amount: {document.gross_amount}</Typography>
                <Typography>Net amount: {document.net_amount}</Typography>
            </Box>
            <Stack direction="row" spacing={1} justifyContent="space-between">
                <Button variant="outlined" color="primary" size="small">Preview</Button>
                <Button variant="outlined" color="secondary" size="small">Edit</Button>
                <Button variant="contained" color="success" size="small">Approve</Button>
                <Button variant="contained" color="error" size="small">Reject</Button>
            </Stack>
        </Paper>
    );
};

export default DocumentCard;
