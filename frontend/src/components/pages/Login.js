import FormInput from "../common/form/FormInput";
import {useFormik} from "formik";
import Box from "@mui/material/Box";
import Button from "../common/Button";
import {useContext} from "react";
import {AuthContext} from "../../contexts/AuthContext";
import {useNavigate} from "react-router-dom";

const Login = () => {

    const {login} = useContext(AuthContext);
    const navigate = useNavigate();

    const handleLogin = async (email, password) => {
        try {
            await login({email, password})
            navigate("/")
        } catch (e) {

            if (e.status === 401) {
                formik.setErrors({password: 'Invalid Email or Password', email: true})
            } else {
                throw e;
            }

        }
    }

    const formik = useFormik({
        initialValues: {email: '', password: ''},
        onSubmit: values => {
            handleLogin(values.email, values.password)
        }
    })

    return <Box
        component="form"
        sx={{
            maxWidth: 400,
            mx: 'auto',
            marginTop: '100px'
        }}
    >
        <FormInput name="email" label="Email" type="email" formik={formik}/>
        <FormInput name="password" label="Password" type="password" formik={formik}/>
        <Button variant="contained" fullWidth type="submit" onClick={formik.submitForm}>Login</Button>
    </Box>

}

export default Login;