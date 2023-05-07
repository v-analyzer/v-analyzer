module psi

pub struct Comment {
	PsiElementImpl
}

fn (n &Comment) get_content() string {
	return ''
}
