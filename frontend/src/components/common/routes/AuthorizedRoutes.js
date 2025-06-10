import {Route, Routes} from "react-router-dom";
import Home from "../../pages/Home";
import {useContext} from "react";
import {AuthContext} from "../../../contexts/AuthContext";
import {ROLES} from "../../../utils/constants";
import Users from "../../pages/Users";

const routes = [
    {path: '/', component: <Home/>, roles: 'all'},
    {path: '/users', component: <Users/>, roles: [ROLES.SUPERADMIN]}
]

const AuthorizedRoutes = () => {
    const {currentUser} = useContext(AuthContext);

    const currentUserRoutes = routes.filter(route => route.roles === 'all' || route.roles.includes(currentUser.role))
    return <Routes>
        {currentUserRoutes.map(route => <Route
            key={route.path} path={route.path} element={route.component}/>)}
    </Routes>
}

export default AuthorizedRoutes;