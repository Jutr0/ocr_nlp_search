import React from 'react';
import {Card, CardContent, Typography} from '@mui/material';
import {Bar} from 'react-chartjs-2';
import {BarElement, CategoryScale, Chart as ChartJS, LinearScale, Tooltip} from 'chart.js';

ChartJS.register(CategoryScale, LinearScale, BarElement, Tooltip);

const ProcessingBarChart = ({data}) => {
    const chartData = {
        labels: data.map(d => d.status),
        datasets: [{
            label: 'Count',
            data: data.map(d => d.count),
            backgroundColor: '#1976d2',
        }],
    };

    const options = {
        responsive: true,
        animation: false,
        plugins: {legend: {display: false}},
        scales: {y: {beginAtZero: true, ticks: {stepSize: 1}}},
    };

    return (
        <Card variant="outlined" sx={{height: '100%'}}>
            <CardContent>
                <Typography variant="h6" gutterBottom>Processing Documents</Typography>
                {data.length > 0 ? <Bar data={chartData} options={options}/> :
                    <Typography color="text.secondary">No data</Typography>}
            </CardContent>
        </Card>
    );
};

export default ProcessingBarChart;
