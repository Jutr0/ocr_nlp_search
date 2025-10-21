import PageHeader from "../../layout/PageHeader";
import DescriptionIcon from '@mui/icons-material/Description';
import {useEffect, useState} from "react";
import Box from "@mui/material/Box";
import Table from "../../common/Table";
import {useNavigate, useParams} from "react-router-dom";
import {buildActions} from "../../../utils/actionsBuilder";
import PageBody from "../../layout/PageBody";
import Button from "../../common/Button";
import DocumentsToReview from './DocumentsToReview.js';

const columns = [
    {field: 'filename', headerName: 'Name'},
    {field: 'created_at', headerName: 'Upload date'},
    {field: 'doc_type', headerName: 'Type'},
    {field: 'status', headerName: 'Status'},
    {field: 'gross_amount', headerName: 'Gross amount'},
]

const Documents = () => {
    const {tab: tabParam} = useParams();

    const [tab, setTab] = useState(tabParam || "all");
    const [documents, setDocuments] = useState([]);
    const navigate = useNavigate();
    const actions = buildActions("document")

    useEffect(() => {
        actions.getAll().then(setDocuments)
    }, []);

    const handleEdit = (document) => {
        navigate(`/documents/edit/${document.id}`)
    }

    const handleAdd = () => {
        navigate(`/documents/new`)
    }
    const handleDelete = ({id}) => {
        actions.delete({id}).then(() => setDocuments(documents.filter(document => document.id !== id)))
    }

    const handleView = (document) => {
        navigate(`/documents/view/${document.id}`)
    }

    const tableActions = [
        {
            label: 'View',
            color: 'info',
            variant: 'outlined',
            onClick: handleView
        }
    ];

    const handleTabChange = (tab) => {
        navigate(`/documents/${tab}`)
        setTab(tab)
    }

    return <Box>
        <PageHeader icon={<DescriptionIcon color="primary"/>} breadcrumbs={[{label: "Documents"}]}
                    tabs={[{label: "All", value: "all"}, {label: "To review", value: "to-review"}]}
                    onTabChange={handleTabChange} activeTab={tab}
                    buttons={<Button variant='outlined' size='small' onClick={handleAdd}>+ Add document</Button>}
        />
        <PageBody withPadding={false}>
            {tab === "all" && <Table
                columns={columns}
                data={documents}
                onEdit={handleEdit}
                onDelete={handleDelete}
                actions={tableActions}
                fullHeight
            />}
            {tab === "to-review" && <DocumentsToReview/>}
        </PageBody>
    </Box>

}

export default Documents;