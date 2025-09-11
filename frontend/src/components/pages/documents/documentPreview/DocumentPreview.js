import Box from "@mui/material/Box";
import {Paper, Typography} from "@mui/material";
import FilePreview from "../../../common/FilePreview";
import React from "react";
import HistoryLogs from "./historyLogs/HistoryLogs";
import DocumentStatus from "./DocumentStatus";
import DocumentCategory from "./DocumentCategory";
import DocumentOcrOutput from "./DocumentOcrOutput";

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
                <DocumentCategory category={document.category}/>
                <DocumentStatus status={document.status}/>
            </Paper>

            <Paper elevation={2} sx={{p: 2}}>
                <DocumentOcrOutput text={document.text_ocr}/>
            </Paper>

            <Paper elevation={2} sx={{p: 2}}>
                <HistoryLogs historyLogs={document.history_logs}/>
            </Paper>
        </Box>
    </Box>
}

export default DocumentPreview;