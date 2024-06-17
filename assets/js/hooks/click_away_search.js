SearchHooks = {
    mounted() {
        this.handleClickAway = this.handleClickAway.bind(this)
        this.handleFocus = this.handleFocus.bind(this)

        document.addEventListener("click", this.handleClickAway)
        let input = document.querySelector("#search")
        if (input) {
            input.addEventListener("focus", this.handleFocus)
        }

    },
    updated() {
        this.handleUpdate()
    },
    destroyed() {
        document.removeEventListener("click", this.handleClickAway)
        let input = document.querySelector("#search")
        if (input) {
            input.removeEventListener("focus", this.handleFocus)
        }

        this.el.removeEventListener("phx:update", this.handleUpdate)
    },
    handleClickAway(event) {
        let searchBox = document.querySelector("#search-box")
        let searchInput = document.querySelector("#search")

        if (searchBox && !searchBox.contains(event.target) && event.target !== searchInput) {
            searchBox.classList.add("fade-out")
            searchBox.classList.remove("fade-in")
            setTimeout(() => {
                searchBox.classList.add("hidden")
            }, 200)
        }
    },
    handleFocus(event) {
        let searchBox = document.querySelector("#search-box")
        console.log(searchBox)
        if (searchBox) {
            searchBox.classList.remove("hidden")
            setTimeout(() => {
                searchBox.classList.remove("fade-out")
                searchBox.classList.add("fade-in")
            }, 10)
        }
    },
    handleUpdate() {
        let searchBox = document.querySelector("#search-box")
        if (searchBox) {
            searchBox.classList.remove("hidden")
            searchBox.classList.remove("fade-out")
            searchBox.classList.add("fade-in")
        }
    }

}
export default SearchHooks