import { useEffect, useState } from "react";
import { get } from "../../../utils/actionsBuilder";
import DocumentCard from "./DocumentCard";
import { Grid, Container } from "@mui/material";
import Box from "@mui/material/Box";

const DocumentsToReview = () => {
    const [documents, setDocuments] = useState([]);
    const actions = {
        getDocumentsToReview: () => get("/documents/to_review"),
    };

    useEffect(() => {
        actions.getDocumentsToReview().then(setDocuments);
    }, []);

    return (
        <Box sx={{ px: 2, py: 4 }}>
            <Grid container spacing={2}>
                {documents.map((d, idx) => (
                    <Grid item xs={12} sm={6} md={4} lg={3} key={idx}>
                        <DocumentCard document={d} />
                    </Grid>
                ))}
            </Grid>
        </Box>
    );
};

export default DocumentsToReview;
