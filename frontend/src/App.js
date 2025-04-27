import Layout from "./components/layout/Layout";
import UploadPage from "./components/pages/UploadPage";
import {Route, Routes} from "react-router-dom";

function App() {
    return <Layout>
        <Routes>
            <Route path="/documents">
                <Route path="new" element={<UploadPage/>}/>
                <Route path="" element={<div>Documents</div>}/>
            </Route>
        </Routes>
    </Layout>
}

export default App;
