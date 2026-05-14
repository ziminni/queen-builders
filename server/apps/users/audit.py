import logging

from .models import AuditLog

logger = logging.getLogger(__name__)


def record_audit(
    *,
    module,
    category,
    summary,
    detail='',
    actor=None,
    actor_email='',
    actor_role='',
):
    if actor is not None and getattr(actor, 'is_authenticated', False):
        actor_email = actor.email
        actor_role = actor.role

    try:
        return AuditLog.objects.create(
            module=module,
            category=category,
            summary=summary,
            detail=detail,
            actor_email=actor_email or '',
            actor_role=actor_role or '',
        )
    except Exception:
        logger.exception('Unable to record audit log')
        return None
