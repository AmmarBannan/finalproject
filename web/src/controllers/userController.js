exports.getUsers = (req, res) => {
    res.json([{ id: 1, name: 'Ammar' }]);
};

exports.createUser = (req, res) => {
    const user = req.body;
    user.id = Date.now();
    res.status(201).json(user);
};
