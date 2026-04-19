import React, {useEffect, useState} from 'react';
import {Alert, CircularProgress, Grid} from '@mui/material';
import Box from '@mui/material/Box';
import PageHeader from '../../layout/PageHeader';
import PageBody from '../../layout/PageBody';
import DashboardIcon from '@mui/icons-material/Dashboard';
import {get} from '../../../utils/actionsBuilder';
import SummaryCards from './SummaryCards';
import CategoryPieChart from './CategoryPieChart';
import ProcessingBarChart from './ProcessingBarChart';
import ExpensesBarChart from './ExpensesBarChart';
import RecentDocumentsTable from './RecentDocumentsTable';
import FlaggedAnomaliesTable from './FlaggedAnomaliesTable';

const Dashboard = () => {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        get('/dashboard')
            .then(setData)
            .catch(() => setError('Failed to load dashboard data.'))
            .finally(() => setLoading(false));
    }, []);

    if (loading) {
        return (
            <Box sx={{display: 'flex', justifyContent: 'center', alignItems: 'center', height: 400}}>
                <CircularProgress/>
            </Box>
        );
    }

    if (error) {
        return (
            <Box sx={{p: 4}}>
                <Alert severity="error">{error}</Alert>
            </Box>
        );
    }

    return (
        <Box>
            <PageHeader
                icon={<DashboardIcon color="primary"/>}
                breadcrumbs={[{label: 'Dashboard'}]}
            />
            <PageBody>
                <Grid container spacing={3}>
                    <Grid item xs={12} md={6}>
                        <SummaryCards summary={data.summary}/>
                    </Grid>
                    <Grid item xs={12} md={6}>
                        <CategoryPieChart data={data.documents_per_category}/>
                    </Grid>
                    <Grid item xs={12} md={6}>
                        <ProcessingBarChart data={data.processing_documents}/>
                    </Grid>
                    <Grid item xs={12} md={6}>
                        <ExpensesBarChart data={data.expenses_by_category}/>
                    </Grid>
                    <Grid item xs={12} md={6}>
                        <RecentDocumentsTable data={data.recent_documents}/>
                    </Grid>
                    <Grid item xs={12} md={6}>
                        <FlaggedAnomaliesTable data={data.flagged_anomalies}/>
                    </Grid>
                </Grid>
            </PageBody>
        </Box>
    );
};

export default Dashboard;
