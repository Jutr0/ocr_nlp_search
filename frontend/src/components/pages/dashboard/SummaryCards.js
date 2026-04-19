import React from 'react';
import {Card, CardContent, Stack, Typography} from '@mui/material';

const StatCard = ({title, value}) => (
    <Card variant="outlined">
        <CardContent>
            <Typography variant="body2" color="text.secondary">{title}</Typography>
            <Typography variant="h4">{value}</Typography>
        </CardContent>
    </Card>
);

const SummaryCards = ({summary}) => {
    return (
        <Stack spacing={2}>
            <StatCard title="All Documents" value={summary.all_documents}/>
            <StatCard title="Documents This Month" value={summary.documents_this_month}/>
            <StatCard title="Documents To Review" value={summary.documents_to_review}/>
        </Stack>
    );
};

export default SummaryCards;
