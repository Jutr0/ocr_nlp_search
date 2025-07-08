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
import DocumentPreview from "./DocumentPreview";

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
                    breadcrumbs={[{label: "Documents", path: "/documents/all"}, {label: `${document?.file?.filename} - View`}]}
                    buttons={<>
                        <Button onClick={actions.refreshOcr} variant='contained'>Refresh OCR</Button>
                        <Button onClick={actions.refreshNlp} variant='contained'>Refresh NLP</Button></>}
        />
        <PageBody>
            <DocumentPreview document={document}/>
        </PageBody>
    </Box>
}

export default DocumentView