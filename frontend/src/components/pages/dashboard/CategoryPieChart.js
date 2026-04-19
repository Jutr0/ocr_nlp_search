import React from 'react';
import {Card, CardContent, Typography} from '@mui/material';
import {Pie} from 'react-chartjs-2';
import {ArcElement, Chart as ChartJS, Legend, Tooltip} from 'chart.js';

ChartJS.register(ArcElement, Tooltip, Legend);

const COLORS = ['#1976d2', '#9c27b0', '#ed6c02', '#2e7d32', '#d32f2f', '#0288d1', '#757575'];

const CategoryPieChart = ({data}) => {
    const chartData = {
        labels: data.map(d => d.category),
        datasets: [{
            data: data.map(d => d.count),
            backgroundColor: COLORS.slice(0, data.length),
        }],
    };

    const options = {
        responsive: true,
        animation: false,
        plugins: {
            legend: {position: 'bottom'},
        },
    };

    return (
        <Card variant="outlined" sx={{height: '100%'}}>
            <CardContent>
                <Typography variant="h6" gutterBottom>Documents per Category</Typography>
                {data.length > 0 ? <Pie data={chartData} options={options}/> :
                    <Typography color="text.secondary">No data</Typography>}
            </CardContent>
        </Card>
    );
};

export default CategoryPieChart;
