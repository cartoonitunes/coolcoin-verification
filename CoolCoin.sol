contract CoolCoin {
    address public organizer;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public target;
    uint256 public quota;
    mapping (address => uint256) public balanceOf;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function CoolCoin(uint256 _target, string _name, string _symbol, uint8 _decimals) {
        if (_target == 0) _target = 10000;
        organizer = msg.sender;
        balanceOf[this] = _target;
        name = _name;
        symbol = _symbol;
        quota = 0;
        decimals = _decimals;
    }

    function Mint(uint256 value) {
        address t = this;
        if (value != quota) return;
        quota++;
        balanceOf[msg.sender] += 100 * quota;
        balanceOf[t] -= 100 * quota;
        Transfer(t, msg.sender, quota);
    }

    function transfer(address _to, uint256 _value) {
        address t = this;
        if (balanceOf[msg.sender] < _value) throw;
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;
        balanceOf[msg.sender] -= _value;
        if (_to == t) {
            balanceOf[_to] += 2 * _value;
        } else {
            balanceOf[_to] += _value;
        }
        quota++;
        Transfer(msg.sender, _to, _value);
    }
}
