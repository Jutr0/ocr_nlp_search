import ChipField from "../../../common/form/readOnly/ChipField";

const statusLabels = {
    pending: "Pending",
    ocr_processing: "OCR Processing",
    ocr_retrying: "OCR Retrying",
    ocr_succeeded: "OCR Succeeded",
    nlp_processing: "NLP Processing",
    nlp_retrying: "NLP Retrying",
    to_review: "To Review",
    approved: "Approved",
};

const statusColors = {
    pending: "default",
    ocr_processing: "info",
    ocr_retrying: "warning",
    ocr_succeeded: "success",
    nlp_processing: "info",
    nlp_retrying: "warning",
    to_review: "secondary",
    approved: "success",
};

const DocumentStatus = ({status}) => {
    return <ChipField
        label="Status"
        value={statusLabels[status] || status}
        color={statusColors[status] || "default"}
    />
}
export default DocumentStatus