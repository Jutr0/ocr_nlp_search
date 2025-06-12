import PageHeader from "../../layout/PageHeader";
import PageBody from "../../layout/PageBody";
import Box from "@mui/material/Box";
import DescriptionIcon from "@mui/icons-material/Description";
import React from "react";

const DocumentView = () => {
    return <Box>
        <PageHeader icon={<DescriptionIcon color="primary"/>}
                    breadcrumbs={[{label: "Documents", path: "/documents"}, {label: "View"}]}/>
        <PageBody>
            Some document view
        </PageBody>
    </Box>
}

export default DocumentView