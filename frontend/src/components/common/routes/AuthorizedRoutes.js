import {Route, Routes} from "react-router-dom";
import {useContext} from "react";
import {AuthContext} from "../../../contexts/AuthContext";
import {ROLES} from "../../../utils/constants";
import Users from "../../pages/Users";
import Documents from "../../pages/documents/Documents";
import UploadDocument from "../../pages/documents/UploadDocument";
import DocumentView from "../../pages/documents/DocumentView";
import Dashboard from "../../pages/dashboard/Dashboard";
import NotFound from "../../pages/NotFound";

const routes = [
    {path: '/dashboard', component: <Dashboard/>, roles: [ROLES.USER]},
    {path: '/documents/new', component: <UploadDocument/>, roles: [ROLES.USER]},
    {path: '/documents/view/:id', component: <DocumentView/>, roles: [ROLES.USER]},
    {path: '/documents/:tab', component: <Documents/>, roles: [ROLES.USER]},
    {path: '/users', component: <Users/>, roles: [ROLES.SUPERADMIN]}
]

const AuthorizedRoutes = () => {
    const {currentUser} = useContext(AuthContext);

    const currentUserRoutes = routes.filter(route => route.roles === 'all' || route.roles.includes(currentUser.role))
    return <Routes>
        {currentUserRoutes.map(route => <Route
            key={route.path} path={route.path} element={route.component}/>)}
        <Route path="*" element={<NotFound/>}/>
    </Routes>
}

export default AuthorizedRoutes;