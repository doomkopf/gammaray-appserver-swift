export class CopyAndClearList<T> {
    private list: T[] = []

    add(elem: T) {
        this.list.push(elem)
    }

    copyAndClear(): T[] | undefined {
        if (this.list.length === 0) {
            return
        }

        const l = this.list
        this.list = []
        return l
    }
}
