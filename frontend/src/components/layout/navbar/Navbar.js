import React, {useContext} from 'react';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import AuthorizedLinks from "./AuthorizedLinks";
import UnauthorizedLinks from "./UnauthorizedLinks";
import {AuthContext} from "../../../contexts/AuthContext";
import AccountCircleIcon from '@mui/icons-material/AccountCircle';

const Navbar = () => {

    const {currentUser} = useContext(AuthContext);

    return (
        <AppBar position="static">
            <Toolbar>
                <Typography variant="h6" component="div" sx={{flexGrow: 1}}>
                    APP TITLE
                </Typography>

                <Box>
                    {currentUser ? <AuthorizedLinks/> : <UnauthorizedLinks/>}
                </Box>
                {currentUser &&
                    <AccountCircleIcon fontSize="large"/>
                }
            </Toolbar>
        </AppBar>
    );
};

export default Navbar;
