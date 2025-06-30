import PageHeader from "../../layout/PageHeader";
import PageBody from "../../layout/PageBody";
import Box from "@mui/material/Box";
import DescriptionIcon from "@mui/icons-material/Description";
import React, {useEffect, useState} from "react";
import {Paper, Typography} from "@mui/material";
import {buildActions, get} from "../../../utils/actionsBuilder";
import {useParams} from "react-router-dom";
import FilePreview from "../../common/FilePreview";
import Button from "../../common/Button";

const DocumentView = () => {
    const {id} = useParams();

    const actions = {
        ...buildActions("document"),
        refreshOcr: () => get(`/documents/${id}/refresh_ocr`),
        refreshNlp: () => get(`/documents/${id}/refresh_nlp`),
    };
    const [document, setDocument] = useState();

    useEffect(() => {
        actions.getOne(id).then(setDocument);
    }, []);

    return <Box>
        <PageHeader icon={<DescriptionIcon color="primary"/>}
                    breadcrumbs={[{label: "Documents", path: "/documents/all"}, {label: "View"}]}
                    buttons={<>
                        <Button onClick={actions.refreshOcr} variant='contained'>Refresh OCR</Button>
                        <Button onClick={actions.refreshNlp} variant='contained'>Refresh NLP</Button></>}
        />
        <PageBody sx={{display: 'flex', gap: 5}}>
            {document && <>
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
            </>
            }
        </PageBody>
    </Box>
}

export default DocumentView