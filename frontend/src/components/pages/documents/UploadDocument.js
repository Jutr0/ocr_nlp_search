import Box from "@mui/material/Box";
import PageHeader from "../../layout/PageHeader";
import PageBody from "../../layout/PageBody";
import DescriptionIcon from "@mui/icons-material/Description";
import FileDropzone from "../../common/Dropzone";
import React from "react";
import {save} from "../../../utils/actionsBuilder";
import {useFormik} from "formik";
import FormInput from "../../common/form/FormInput";
import Button from "../../common/Button";
import {useNavigate} from "react-router-dom";

const UploadDocument = () => {
const navigate = useNavigate();

    const handleSave = (values) => {
        const formData = new FormData();
        if (values.file) {
            formData.append("file", values.file, values.filename);
        }

        actions.createDocument(formData).then(({id}) => navigate(`/documents/${id}`));
    };

    const formik = useFormik({
        initialValues: {
            filename: null,
            file: null,
        },
        onSubmit: handleSave,
    });

    const actions = {createDocument: document => save('/documents', 'POST', document)}


    const handleDrop = (files) => {
        if (files.length === 0) return

        formik.setFieldValue('file', files[0])
        if (!formik.values.filename) {
            formik.setFieldValue('filename', files[0].name)
        }
    }

    return <Box>
        <PageHeader icon={<DescriptionIcon color="primary"/>}
                    breadcrumbs={[{label: "Documents", path: "/documents"}, {label: "New"}]}
                    buttons={<Button variant='contained' size="small" onClick={formik.handleSubmit}>Save &
                        Process</Button>}
        />
        <PageBody>
            <Box component="form" onSubmit={formik.handleSubmit}>
                <FormInput name="filename" label="Filename" formik={formik}/>
                <FileDropzone onDrop={handleDrop} value={formik.values.file}/>
            </Box>
        </PageBody>
    </Box>
}

export default UploadDocument