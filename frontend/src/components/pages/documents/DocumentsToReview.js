import {useEffect, useState} from "react";
import {get, save} from "../../../utils/actionsBuilder";
import DocumentCard from "./DocumentCard";
import {Grid} from "@mui/material";
import Box from "@mui/material/Box";

const DocumentsToReview = () => {
    const [documents, setDocuments] = useState([]);
    const actions = {
        getDocumentsToReview: () => get("/documents/to_review"),
        approve: (id) => save(`/documents/${id}/approve`, 'POST'),
        reject: (id) => save(`/documents/${id}/reject`, 'POST'),
    };

    useEffect(() => {
        actions.getDocumentsToReview().then(setDocuments);
    }, []);
    const handleApprove = (id) => {
        actions.approve(id).then(() => setDocuments(documents.filter(d => d.id !== id)));
    }
    const handleReject = (id) => {
        actions.reject(id).then(() => setDocuments(documents.filter(d => d.id !== id)));
    }
    return (
        <Box sx={{px: 2, py: 4}}>
            <Grid container spacing={2}>
                {documents.map((d, idx) => (
                    <Grid item xs={12} sm={6} md={4} lg={3} key={idx}>
                        <DocumentCard document={d} onApprove={handleApprove} onReject={handleReject}/>
                    </Grid>
                ))}
            </Grid>
        </Box>
    );
};

export default DocumentsToReview;
