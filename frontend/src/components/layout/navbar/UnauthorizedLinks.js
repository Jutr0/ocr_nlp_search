import Button from "../../common/Button";
import {NavLink} from "react-router-dom";
import React from "react";

const UnauthorizedLinks = () => {

    return <>
        <Button
            color="inherit"
            component={NavLink}
            to="/login"
        >
            Login
        </Button>
        <Button
            color="inherit"
            component={NavLink}
            to="/register"
        >
            Register
        </Button>
    </>
}


export default UnauthorizedLinks;