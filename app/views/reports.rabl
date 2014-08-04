collection @reports
	attributes :id, :today, :today, :tomorrow, :summary, :data_format
	child(:user) {
		attribute(:id, :name, :avatar_url, :title)
	} 