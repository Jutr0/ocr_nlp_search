import React from 'react';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Button from '../common/Button';
import {useNavigate} from 'react-router-dom';

const NotFound = () => {
    const navigate = useNavigate();

    return (
        <Box sx={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            height: '100%',
            textAlign: 'center',
            p: 3
        }}>
            <Typography variant="h1" sx={{fontSize: '6rem', fontWeight: 700, color: 'primary.main'}}>
                404
            </Typography>
            <Typography variant="h5" sx={{mb: 1, color: 'text.secondary'}}>
                Page not found
            </Typography>
            <Typography variant="body1" sx={{mb: 3, color: 'text.disabled'}}>
                The page you're looking for doesn't exist or has been moved.
            </Typography>
            <Button variant="contained" onClick={() => navigate(-1)}>
                Go Back
            </Button>
        </Box>
    );
};

export default NotFound;
