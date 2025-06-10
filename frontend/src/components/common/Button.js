import MUIButton from "@mui/material/Button";

const Button = ({children, onClick, ...props}) => {

    const handleClick = (e) => {
        if (onClick) {
            e.preventDefault();
            onClick(e);
        }
    }

    return <MUIButton onClick={handleClick} {...props}>{children}</MUIButton>
}

export default Button;