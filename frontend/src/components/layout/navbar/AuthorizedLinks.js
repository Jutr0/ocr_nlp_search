import Button from "../../common/Button";
import {NavLink, useNavigate} from "react-router-dom";
import React, {useContext} from "react";
import {AuthContext} from "../../../contexts/AuthContext";
import {ROLES} from "../../../utils/constants";

const links = [
    {path: '/', label: 'Home', roles: 'all'},
    {path: '/users', label: 'Users', roles: [ROLES.SUPERADMIN]},
]

const AuthorizedLinks = () => {

    const {logout, currentUser} = useContext(AuthContext);
    const navigate = useNavigate();

    const handleLogout = async () => {
        await logout()
        navigate("/login")
    }

    const currentUserLinks = links.filter(link => link.roles === 'all' || link.roles.includes(currentUser.role));

    return <>
        {currentUserLinks.map(link => <Button
            color="inherit"
            component={NavLink}
            to={link.path}
        >
            {link.label}
        </Button>)}
        <Button
            color="inherit"
            onClick={handleLogout}
        >
            Logout
        </Button>
    </>
}


export default AuthorizedLinks;