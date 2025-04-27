import React from 'react';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import Box from '@mui/material/Box';
import {NavLink} from "react-router-dom";

const Navbar = () => {
    return (
        <AppBar position="static">
            <Toolbar>
                <Typography variant="h6" component="div" sx={{flexGrow: 1}}>
                    OCR-NLP-SEARCH
                </Typography>

                <Box>
                    <Button
                        color="inherit"
                        component={NavLink}
                        to="/documents"
                    >
                        Documents
                    </Button>
                    <Button
                        color="inherit"
                        component={NavLink}
                        to="/documents/new"
                    >
                        + Add Document
                    </Button>
                </Box>
            </Toolbar>
        </AppBar>
    );
};

export default Navbar;
