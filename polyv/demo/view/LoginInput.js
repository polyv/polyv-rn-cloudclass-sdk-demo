import {
    TextInput,
} from "react-native";

export default class LoginInput {
    onFocus = () => {
        const { onFocus } = this.props;
        onFocus && onFocus();
    }

    render() {
        return (
            <TextInput onFocus={this.onFocus} />
        )
    }

}