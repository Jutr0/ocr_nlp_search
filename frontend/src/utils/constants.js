export const ROLES = {SUPERADMIN: 'superadmin', USER: 'user'}

export const CATEGORY_LABELS = {
    it_services: 'IT Services',
    office_supplies: 'Office Supplies',
    travel_and_transportation: 'Travel & Transportation',
    marketing_and_advertising: 'Marketing & Advertising',
    legal_and_accounting: 'Legal & Accounting',
    utilities_and_subscriptions: 'Utilities & Subscriptions',
    other: 'Other',
};

export const categoryLabel = (value) => CATEGORY_LABELS[value] || value;