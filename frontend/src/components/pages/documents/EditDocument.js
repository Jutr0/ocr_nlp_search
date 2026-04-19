import Box from "@mui/material/Box";
import PageHeader from "../../layout/PageHeader";
import PageBody from "../../layout/PageBody";
import DescriptionIcon from "@mui/icons-material/Description";
import React, {useEffect, useState} from "react";
import {buildActions, save} from "../../../utils/actionsBuilder";
import {useNavigate, useParams} from "react-router-dom";
import {useFormik} from "formik";
import FormInput from "../../common/form/FormInput";
import FormSelect from "../../common/form/FormSelect";
import FormDatePicker from "../../common/form/FormDatePicker";
import Button from "../../common/Button";
import dayjs from "dayjs";
import {CATEGORY_LABELS} from "../../../utils/constants";

const docTypeOptions = [
    {value: 'invoice', label: 'Invoice'},
    {value: 'bill', label: 'Bill'},
    {value: 'receipt', label: 'Receipt'},
    {value: 'other', label: 'Other'},
];

const categoryOptions = Object.entries(CATEGORY_LABELS).map(([value, label]) => ({value, label}));

const currencyOptions = [
    {value: 'PLN', label: 'PLN'},
    {value: 'EUR', label: 'EUR'},
    {value: 'USD', label: 'USD'},
    {value: 'GBP', label: 'GBP'},
];

const EditDocument = () => {
    const {id} = useParams();
    const navigate = useNavigate();
    const actions = buildActions("document");
    const [loading, setLoading] = useState(true);
    const [filename, setFilename] = useState('');

    const formik = useFormik({
        initialValues: {
            doc_type: '',
            category: '',
            invoice_number: '',
            issue_date: null,
            company_name: '',
            nip: '',
            net_amount: '',
            gross_amount: '',
            currency: '',
        },
        enableReinitialize: true,
        onSubmit: (values) => {
            const payload = {
                ...values,
                issue_date: values.issue_date ? dayjs(values.issue_date).format('YYYY-MM-DD') : '',
            };
            save(`/documents/${id}`, 'PATCH', payload).then(() => {
                navigate(`/documents/view/${id}`);
            });
        },
    });

    useEffect(() => {
        actions.getOne(id).then((doc) => {
            setFilename(doc.file?.filename || '');
            formik.setValues({
                doc_type: doc.doc_type || '',
                category: doc.category || '',
                invoice_number: doc.invoice_number || '',
                issue_date: doc.issue_date ? dayjs(doc.issue_date) : null,
                company_name: doc.company_name || '',
                nip: doc.nip || '',
                net_amount: doc.net_amount || '',
                gross_amount: doc.gross_amount || '',
                currency: doc.currency || '',
            });
            setLoading(false);
        });
    }, []);

    if (loading) return null;

    return <Box>
        <PageHeader icon={<DescriptionIcon color="primary"/>}
                    breadcrumbs={[
                        {label: "Documents", path: "/documents/all"},
                        {label: `${filename} - Edit`}
                    ]}
                    buttons={<>
                        <Button variant="contained" onClick={formik.handleSubmit}>Save</Button>
                        <Button variant="outlined" onClick={() => navigate(`/documents/view/${id}`)}>Cancel</Button>
                    </>}
        />
        <PageBody>
            <Box component="form" onSubmit={formik.handleSubmit} sx={{maxWidth: 600}}>
                <FormSelect name="doc_type" label="Document Type" options={docTypeOptions} formik={formik}/>
                <FormSelect name="category" label="Category" options={categoryOptions} formik={formik}/>
                <FormInput name="invoice_number" label="Invoice Number" formik={formik}/>
                <FormDatePicker name="issue_date" label="Issue Date" formik={formik}/>
                <FormInput name="company_name" label="Company Name" formik={formik}/>
                <FormInput name="nip" label="NIP" formik={formik}/>
                <FormInput name="net_amount" label="Net Amount" type="number" formik={formik}/>
                <FormInput name="gross_amount" label="Gross Amount" type="number" formik={formik}/>
                <FormSelect name="currency" label="Currency" options={currencyOptions} formik={formik}/>
            </Box>
        </PageBody>
    </Box>
};

export default EditDocument;
