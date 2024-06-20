SearchHooks = {
    mounted() {
        this.handleClickAway = this.handleClickAway.bind(this)
        this.handleFocus = this.handleFocus.bind(this)

        document.addEventListener("click", this.handleClickAway)
        let input = document.querySelector("#search")
        if (input) {
            input.addEventListener("focus", this.handleFocus)
        }

        this.handleEvent("update-artists", (ev) => {
            this.handleUpdated(ev.refresh)
        })

    },
    destroyed() {
        document.removeEventListener("click", this.handleClickAway)
        let input = document.querySelector("#search")
        if (input) {
            input.removeEventListener("focus", this.handleFocus)
        }
    },
    handleUpdated(refresh) {
        let searchBox = document.querySelector("#search-box")
        if (searchBox && refresh) {
            searchBox.classList.remove("hidden")
            searchBox.classList.remove("fade-out")
            searchBox.classList.add("fade-in")
        }
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
        if (searchBox) {
            searchBox.classList.remove("hidden")
            setTimeout(() => {
                searchBox.classList.remove("fade-out")
                searchBox.classList.add("fade-in")
            }, 10)
        }
    },
}
export default SearchHooks