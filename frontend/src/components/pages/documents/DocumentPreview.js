import Box from "@mui/material/Box";
import {Paper, Typography} from "@mui/material";
import FilePreview from "../../common/FilePreview";
import React from "react";

const DocumentPreview = ({document}) => {

    return document && <Box sx={{display: 'flex', gap: 5}}>
        <Box flex={1} sx={{
            height: "100%",
            position: "sticky",
            top: 0
        }}>
            <Paper elevation={2} sx={{p: 2, height: '100%'}}>
                <Box
                    sx={{
                        backgroundColor: "#f0f0f0",
                        height: "100%",
                        borderRadius: 1
                    }}
                >
                    {document?.file && <FilePreview file={document.file}/>}
                </Box>
            </Paper>
        </Box>

        <Box flex={1} display="flex" flexDirection="column" gap={2} maxWidth='50%'>
            <Paper elevation={2} sx={{p: 2}}>
                <Typography variant="h6" gutterBottom>
                    Extracted Data
                </Typography>
                <Typography>Document type: {document.doc_type}</Typography>
                <Typography>Invoice number: {document.invoice_number}</Typography>
                <Typography>Company name: {document.company_name}</Typography>
                <Typography>Issue date: {document.issue_date}</Typography>
                <Typography>Gross amount: {document.gross_amount}</Typography>
                <Typography>Net amount: {document.net_amount}</Typography>
                <Typography>Currency: {document.currency}</Typography>
                <Typography>Nip: {document.nip}</Typography>
            </Paper>
            <Paper elevation={2} sx={{p: 2}}>

                <Typography variant="h6" gutterBottom>
                    Category {document.category}
                </Typography>
                <Typography variant="h6" gutterBottom>
                    Status {document.status}
                </Typography>
            </Paper>

            <Paper elevation={2} sx={{p: 2}}>
                <Typography variant="h6" gutterBottom>
                    OCR Output
                </Typography>
                <Typography variant="body" gutterBottom>
                    {document.text_ocr}
                </Typography>
            </Paper>

            <Paper elevation={2} sx={{p: 2}}>
                <Typography variant="h6" gutterBottom>
                    History
                </Typography>
            </Paper>
        </Box>
    </Box>
}

export default DocumentPreview;