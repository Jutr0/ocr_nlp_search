import ChipField from "../../../common/form/readOnly/ChipField";

const categoryLabels = {
    it_services: "IT Services",
    office_supplies: "Office Supplies",
    travel_and_transportation: "Travel & Transportation",
    marketing_and_advertising: "Marketing & Advertising",
    legal_and_accounting: "Legal & Accounting",
    utilities_and_subscriptions: "Utilities & Subscriptions",
    other: "Other",
};

const categoryColors = {
    it_services: "info",
    office_supplies: "secondary",
    travel_and_transportation: "warning",
    marketing_and_advertising: "primary",
    legal_and_accounting: "default",
    utilities_and_subscriptions: "success",
    other: "default",
};

const DocumentCategory = ({category}) => {
    return (
        <ChipField
            label="Category"
            value={categoryLabels[category] || category}
            color={categoryColors[category] || "default"}
        />
    );
};

export default DocumentCategory;
