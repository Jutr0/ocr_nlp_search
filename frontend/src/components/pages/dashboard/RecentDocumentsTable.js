import React from 'react';
import {Card, CardContent, Chip, Typography} from '@mui/material';
import Table from '../../common/Table';

const statusLabels = {
    pending: 'Pending',
    ocr_processing: 'OCR Processing',
    ocr_retrying: 'OCR Retrying',
    ocr_succeeded: 'OCR Succeeded',
    nlp_processing: 'NLP Processing',
    nlp_retrying: 'NLP Retrying',
    to_review: 'To Review',
    approved: 'Approved',
};

const statusColors = {
    pending: 'default',
    ocr_processing: 'info',
    ocr_retrying: 'warning',
    ocr_succeeded: 'success',
    nlp_processing: 'info',
    nlp_retrying: 'warning',
    to_review: 'secondary',
    approved: 'success',
};

const columns = [
    {field: 'doc_number', headerName: 'Doc Number'},
    {field: 'upload_date', headerName: 'Upload Date'},
    {field: 'category', headerName: 'Category'},
    {
        field: 'status', headerName: 'Status', render: (value) => (
            <Chip
                label={statusLabels[value] || value}
                color={statusColors[value] || 'default'}
                size="small"
                variant="filled"
            />
        )
    },
    {field: 'amount', headerName: 'Amount'},
];

const RecentDocumentsTable = ({data}) => {
    return (
        <Card variant="outlined" sx={{height: '100%'}}>
            <CardContent>
                <Typography variant="h6" gutterBottom>Recent Documents</Typography>
                <Table columns={columns} data={data}/>
            </CardContent>
        </Card>
    );
};

export default RecentDocumentsTable;
