Array.prototype.swap = function(i, j) {
    const temp = this[i];
    this[i] = this[j];
    this[j] = temp;
};

// Fisher-Yates shuffle
Array.prototype.shuffle = function() {
    for (let i = this.length - 1; i > 0; i -= 1) {
        const j = Math.floor(Math.random() * (i + 1));
        this.swap(i, j);
    }

    return this;
};

Array.prototype.pick = function() {
    return this[Math.floor(Math.random() * this.length)];
}
