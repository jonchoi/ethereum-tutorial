event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => bool) public frozenAccount; // is this in the correct spot?
event FrozenFunds(address indexed, bool frozen);

contract owned { // Why isn't this capitalized?
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _; //what's this line about
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract MyToken is owned {
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    /* function name has to be the same as contract name */
    function MyToken(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        uint8 decimalUnits
        address centralMinter
    ) {
        if (centralMinter != 0) owner = centralMinter;

        /* user who deployed the contract will start with a balance of 21 million*/
        balanceOf[msg.sender] = initialSupply;
        name = tokenName;
        symbol = tokenSymbol;
        decimals = decimalUnits;
        totalSupply = initialSupply;
    } // the contract will be called only once at init
}

/* Send coins */
function transfer(address _to, uint256 _value) {
    if (frozenAccount[msg.sender]) throw;

    /* Check if sender has balance and for overflows */
    if (balanceOf[msg.sender] < _value || balanceOf[_to] + _value < balanceOf[_to]) {
        throw;
    }
    /* Add and subtract new balances */
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;

    /* Notify anyone listening that this transfer took place */
    Transfer(msg.sender, _to, _value);
}

function mintToken(address target, uint256 mintedAmount) onlyOwner {
    balanceOf[target] += mintedAmount;
    totalSupply += mintedAmount;
    Transfer(0, owner, mintedAmount); // comes out of thin air lol
    Transfer(owner, target, mintedAmount);
}

function freezeAccount(address target, bool freeze) onlyOwner {
    frozenAccount[target] = freeze;
    FrozenFunds(target, freeze);
}
