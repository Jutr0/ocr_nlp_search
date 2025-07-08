import React from 'react';
import {Box, Paper, Stack, Typography} from '@mui/material';
import DocumentPreviewModal from "./DocumentPreviewModal";
import Button from "../../common/Button";

const DocumentCard = ({document, onReject, onApprove}) => {
    const isImage = (type) => type?.startsWith('image/');
    const [modalOpen, setModalOpen] = React.useState(null);


    return <>
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
                <Button variant="outlined" color="primary" size="small"
                        onClick={() => setModalOpen('preview')}>View</Button>
                <Button variant="outlined" color="secondary" size="small">Edit</Button>
                <Button variant="contained" color="success" size="small"
                        onClick={() => onApprove(document.id)}>Approve</Button>
                <Button variant="contained" color="error" size="small"
                        onClick={() => onReject(document.id)}>Reject</Button>
            </Stack>
        </Paper>
        {modalOpen === "preview" &&
            <DocumentPreviewModal document={document} onClose={() => setModalOpen(null)} onApprove={onApprove}
                                  onReject={onReject}/>}
    </>

};

export default DocumentCard;
