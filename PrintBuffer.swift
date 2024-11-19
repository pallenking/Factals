...
struct ClassBox : View {
	let labeled: String						// arg1
	let isFirst:Bool = false				// arg2
	var body: some View {
		Text(labeled)
...
	var body: some View {
		HStack {
			ClassBox(labeled:"Broadcast", isFirst:isFirst)
			Spacer()
		}
	}

Error: 'isFirst' is not declared in this scope
