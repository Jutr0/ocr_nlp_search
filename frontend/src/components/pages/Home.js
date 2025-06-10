import React from 'react';
import {useFormik} from "formik";
import * as Yup from "yup";
import Box from "@mui/material/Box";
import FormInput from "../common/form/FormInput";
import FormSelect from "../common/form/FormSelect";
import FormDatePicker from "../common/form/FormDatePicker";
import FormCheckbox from "../common/form/FormCheckbox";
import Button from "../common/Button";

const validationSchema = Yup.object({
    name: Yup.string().required('Required'),
    email: Yup.string().email('Incorrect email').required('Required'),
});
const Home = () => {
    const formik = useFormik({
        initialValues: {name: '', email: ''},
        validationSchema,
        onSubmit: values => console.log(values),
    });

    return (
        <Box component="form" onSubmit={formik.handleSubmit} sx={{mt: 2}}>
            <FormInput name="name" label="Name" formik={formik}/>
            <FormInput name="email" label="Email" type="email" formik={formik}/>
            <FormSelect
                name="position"
                label="Position"
                options={[
                    {value: 'setter', label: 'Setter'},
                    {value: 'spiker', label: 'Spiker'},
                    {value: 'libero', label: 'Libero'},
                ]}
                formik={formik}
            />
            <FormDatePicker
                name="practiceDate"
                label="Practice Date"
                formik={formik}
            />
            <FormCheckbox name="isAvailable" label="Is Available" formik={formik}/>
            <Button type="submit" variant="contained" fullWidth sx={{mt: 3}}>
                Save
            </Button>
        </Box>
    );
};

export default Home;
