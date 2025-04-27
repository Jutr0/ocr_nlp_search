import React from 'react';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import Box from '@mui/material/Box';

const Navbar = () => {
    return (
        <AppBar position="static">
            <Toolbar>
                <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
                    OCR-NLP-SEARCH
                </Typography>

                <Box>
                    <Button color="inherit">Documents</Button>
                    <Button color="inherit">+ Add Document</Button>
                </Box>
            </Toolbar>
        </AppBar>
    );
};

export default Navbar;
