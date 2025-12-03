/// Barrel file para el feature de autenticación
library;

// Data - Models
export 'data/models/models.dart';

// Data - Repositories
export 'data/repositories/auth_repository.dart';

// Domain - Entities
export 'domain/entities/user.dart';

// Presentation - Bloc
export 'presentation/bloc/auth_bloc.dart';
export 'presentation/bloc/auth_event.dart';
export 'presentation/bloc/auth_state.dart';

// Presentation - Cubit
export 'presentation/cubit/cubit.dart';

// Presentation - Pages
export 'presentation/pages/login_page.dart';
export 'presentation/pages/register_page.dart';
export 'presentation/pages/forgot_password/forgot_password_pages.dart';

