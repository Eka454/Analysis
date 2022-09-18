WITH id_sessions AS (
	SELECT id, action, time, SUM(duration) OVER (PARTITION BY id order by id, time) sessions
	FROM (	
			SELECT *, CASE 
					WHEN EXTRACT(hour FROM time - LAG(time,1, "time") OVER (PARTITION BY id order by id, time)) > 0 
					THEN 1 
					ELSE 0 
					END duration
			FROM vimbox_pages
		) duration_table
), right_sessions AS (
	SELECT id, sessions
	FROM (	
		SELECT 	id, sessions, STRING_AGG (action, ', ') all_actions
		FROM id_sessions
		WHERE action = 'rooms.homework-showcase' OR action = 'rooms.view.step.content' OR action = 'rooms.lesson.rev.step.content'
		GROUP BY id, sessions) actions
	WHERE all_actions LIKE '%homework-showcase%view.step.content%lesson.rev.step.content%'
)

SELECT id_sessions.id, min(time) start_session , max(time) end_session
FROM id_sessions 
RIGHT JOIN right_sessions
ON id_sessions.id = right_sessions.id AND id_sessions.sessions = right_sessions.sessions
GROUP BY id_sessions.id, id_sessions.sessions