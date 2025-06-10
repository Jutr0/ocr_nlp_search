import PageHeader from "../../layout/PageHeader";
import DescriptionIcon from '@mui/icons-material/Description';
import {useEffect, useState} from "react";
import Box from "@mui/material/Box";
import Table from "../../common/Table";
import {useNavigate} from "react-router-dom";
import {buildActions} from "../../../utils/actionsBuilder";
import PageBody from "../../layout/PageBody";

const columns = [
    {field: 'filename', headerName: 'Name'},
    {field: 'created_at', headerName: 'Upload Date'},
    {field: 'doc_type', headerName: 'Type'},
    {field: 'status', headerName: 'Status'},
    {field: 'amount', headerName: 'Amount'},
]

const Documents = () => {
    const [tab, setTab] = useState("All");
    const [documents, setDocuments] = useState([]);
    const navigate = useNavigate();
    const actions = buildActions("document")
    const handleEdit = (document) => {
        navigate(`/documents/${document.id}/edit`)
    }
    useEffect(() => {
        actions.getAll().then(setDocuments)
    }, []);

    return <Box >
        <PageHeader icon={<DescriptionIcon color="primary"/>} header="Documents"
                    tabs={[{label: "All"}, {label: "To review"}]} onTabChange={setTab} activeTab={tab}/>
        <PageBody>
            <Table
                columns={columns}
                data={documents}
                onEdit={handleEdit}
                fullHeight
            />
        </PageBody>
    </Box>

}

export default Documents;