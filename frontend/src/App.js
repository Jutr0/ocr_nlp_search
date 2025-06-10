import Layout from "./components/layout/Layout";
import AuthorizedRoutes from "./components/common/routes/AuthorizedRoutes";
import UnauthorizedRoutes from "./components/common/routes/UnauthorizedRoutes";
import {AuthContext} from "./contexts/AuthContext";
import {useContext} from "react";

function App() {
    const {currentUser} = useContext(AuthContext);

    return (
        <Layout>
            {currentUser ? <AuthorizedRoutes/> : <UnauthorizedRoutes/>}
        </Layout>
    );
}

export default App;
