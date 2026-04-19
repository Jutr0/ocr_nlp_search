import React from 'react';
import {Card, CardContent, Typography} from '@mui/material';
import {Bar} from 'react-chartjs-2';
import {BarElement, CategoryScale, Chart as ChartJS, LinearScale, Tooltip} from 'chart.js';
import {categoryLabel} from '../../../utils/constants';

ChartJS.register(CategoryScale, LinearScale, BarElement, Tooltip);

const ExpensesBarChart = ({data}) => {
    const chartData = {
        labels: data.map(d => categoryLabel(d.category)),
        datasets: [{
            label: 'Total Amount',
            data: data.map(d => d.total),
            backgroundColor: '#2e7d32',
        }],
    };

    const options = {
        responsive: true,
        animation: false,
        plugins: {legend: {display: false}},
        scales: {y: {beginAtZero: true}},
    };

    return (
        <Card variant="outlined" sx={{height: '100%'}}>
            <CardContent>
                <Typography variant="h6" gutterBottom>Expenses by Category</Typography>
                {data.length > 0 ? <Bar data={chartData} options={options}/> :
                    <Typography color="text.secondary">No data</Typography>}
            </CardContent>
        </Card>
    );
};

export default ExpensesBarChart;
