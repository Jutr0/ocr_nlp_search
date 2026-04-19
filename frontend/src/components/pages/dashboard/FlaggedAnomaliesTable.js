import React from 'react';
import {Card, CardContent, Typography} from '@mui/material';
import Table from '../../common/Table';
import {categoryLabel} from '../../../utils/constants';

const columns = [
    {field: 'doc_number', headerName: 'Doc Number'},
    {field: 'category', headerName: 'Category', render: (value) => categoryLabel(value)},
    {field: 'amount', headerName: 'Amount'},
    {field: 'ocr_confidence', headerName: 'OCR %'},
    {field: 'nlp_confidence', headerName: 'NLP %'},
];

const FlaggedAnomaliesTable = ({data}) => {
    return (
        <Card variant="outlined" sx={{height: '100%'}}>
            <CardContent>
                <Typography variant="h6" gutterBottom>Flagged Anomalies</Typography>
                <Table columns={columns} data={data}/>
            </CardContent>
        </Card>
    );
};

export default FlaggedAnomaliesTable;
