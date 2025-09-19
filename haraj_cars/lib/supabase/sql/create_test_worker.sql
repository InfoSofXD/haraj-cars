-- Worker Management SQL Scripts
-- Use these scripts to manage workers in your Supabase database

-- 1. View all workers
SELECT 
  id,
  worker_name,
  worker_phone,
  worker_email,
  created_at,
  last_login
FROM public.workers_list 
ORDER BY created_at DESC;

-- 2. Create a new worker (replace with actual data)
-- INSERT INTO public.workers_list (
--   worker_name,
--   worker_phone,
--   worker_email,
--   worker_password,
--   worker_uuid
-- ) VALUES (
--   'Worker Name',
--   '+1234567890',
--   'worker@email.com',
--   'password123',
--   gen_random_uuid()
-- );

-- 3. Update a worker's password
-- UPDATE public.workers_list 
-- SET worker_password = 'new_password'
-- WHERE worker_name = 'Worker Name';

-- 4. Delete a worker
-- DELETE FROM public.workers_list 
-- WHERE worker_name = 'Worker Name';

-- 5. Search workers by name
-- SELECT * FROM public.workers_list 
-- WHERE worker_name ILIKE '%search_term%';

-- 6. Search workers by phone
-- SELECT * FROM public.workers_list 
-- WHERE worker_phone ILIKE '%search_term%';
