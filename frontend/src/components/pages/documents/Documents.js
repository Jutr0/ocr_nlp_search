import PageHeader from "../../layout/PageHeader";
import DescriptionIcon from '@mui/icons-material/Description';
import {useEffect, useState} from "react";
import Box from "@mui/material/Box";
import Table from "../../common/Table";
import {useNavigate} from "react-router-dom";
import {buildActions} from "../../../utils/actionsBuilder";
import PageBody from "../../layout/PageBody";
import Button from "../../common/Button";

const columns = [
    {field: 'filename', headerName: 'Name'},
    {field: 'created_at', headerName: 'Upload date'},
    {field: 'doc_type', headerName: 'Type'},
    {field: 'status', headerName: 'Status'},
    {field: 'gross_amount', headerName: 'Gross amount'},
]

const Documents = () => {
    const [tab, setTab] = useState("All");
    const [documents, setDocuments] = useState([]);
    const navigate = useNavigate();
    const actions = buildActions("document")

    useEffect(() => {
        actions.getAll().then(setDocuments)
    }, []);

    const handleEdit = (document) => {
        navigate(`/documents/${document.id}/edit`)
    }

    const handleAdd = () => {
        navigate(`/documents/new`)
    }
    const handleDelete = ({id}) => {
        actions.delete({id}).then(() => setDocuments(documents.filter(document => document.id !== id)))
    }

    const handleView = (document) => {
        navigate(`/documents/${document.id}`)
    }

    const tableActions = [
        {
            label: 'View',
            color: 'info',
            variant: 'outlined',
            onClick: handleView
        }
    ];
    return <Box>
        <PageHeader icon={<DescriptionIcon color="primary"/>} breadcrumbs={[{label: "Documents"}]}
                    tabs={[{label: "All"}, {label: "To review"}]} onTabChange={setTab} activeTab={tab}
                    buttons={<Button variant='outlined' size='small' onClick={handleAdd}>+ Add document</Button>}
        />
        <PageBody withPadding={false}>
            <Table
                columns={columns}
                data={documents}
                onEdit={handleEdit}
                onDelete={handleDelete}
                actions={tableActions}
                fullHeight
            />
        </PageBody>
    </Box>

}

export default Documents;